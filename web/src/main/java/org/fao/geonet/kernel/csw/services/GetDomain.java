//=============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.kernel.csw.services;

import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.MapFieldSelector;
import org.apache.lucene.search.CachingWrapperFilter;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.Sort;
import org.apache.lucene.search.TopDocs;
import org.apache.lucene.util.ReaderUtil;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.csw.common.Csw;
import org.fao.geonet.csw.common.exceptions.CatalogException;
import org.fao.geonet.csw.common.exceptions.NoApplicableCodeEx;
import org.fao.geonet.csw.common.exceptions.OperationNotSupportedEx;
import org.fao.geonet.kernel.csw.CatalogConfiguration;
import org.fao.geonet.kernel.csw.CatalogDispatcher;
import org.fao.geonet.kernel.csw.CatalogService;
import org.fao.geonet.kernel.csw.services.getrecords.CatalogSearcher;
import org.fao.geonet.kernel.search.LuceneSearcher;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.search.SummaryComparator;
import org.fao.geonet.kernel.search.SummaryComparator.SortOption;
import org.fao.geonet.kernel.search.SummaryComparator.Type;
import org.fao.geonet.kernel.search.spatial.Pair;
import org.jdom.Element;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.SortedSet;
import java.util.TreeSet;

//=============================================================================

public class GetDomain extends AbstractOperation implements CatalogService
{
	//---------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//---------------------------------------------------------------------------

	public GetDomain() {}

	//---------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//---------------------------------------------------------------------------

	public String getName() { return "GetDomain"; }

	//---------------------------------------------------------------------------

	public Element execute(Element request, ServiceContext context) throws CatalogException
	{
		checkService(request);
		checkVersion(request);
		
		Element response = new Element(getName() +"Response", Csw.NAMESPACE_CSW);
		
		String[] propertyNames = getParameters(request, "PropertyName");
		String[] parameterNames = getParameters(request, "ParameterName");

		// PropertyName handled first. 
		if (propertyNames != null) {
			List<Element> domainValues;
			try {
				domainValues = handlePropertyName(propertyNames, context, false, CatalogConfiguration.getMaxNumberOfRecordsForPropertyNames());
			} catch (Exception e) {
							e.printStackTrace();
	            Log.error(Geonet.CSW, "Error getting domain value for specified PropertyName : " + e);
	            throw new NoApplicableCodeEx(
	                    "Raised exception while getting domain value for specified PropertyName  : " + e);
	        }
			response.addContent(domainValues);
			return response;
		}
		
		if (parameterNames != null) {
			List<Element> domainValues = handleParameterName(parameterNames);
			response.addContent(domainValues);
		}
		
		return response;
	}

	//---------------------------------------------------------------------------

	public Element adaptGetRequest(Map<String, String> params)
	{
		String service        = params.get("service");
		String version        = params.get("version");
		String parameterName  = params.get("parametername");
		String propertyName   = params.get("propertyname");
		
		Element request = new Element(getName(), Csw.NAMESPACE_CSW);
		
		setAttrib(request, "service",        service);
		setAttrib(request, "version",        version);
		
		//--- these 2 are in mutual exclusion.
		Element propName  = new Element("PropertyName", Csw.NAMESPACE_CSW).setText(propertyName);
		Element paramName  = new Element("ParameterName", Csw.NAMESPACE_CSW).setText(parameterName);
		
		// Property is handled first.
		if (propertyName != null && !propertyName.equals(""))
			request.addContent(propName);
		else if (parameterName != null && !parameterName.equals(""))
			request.addContent(paramName);

		return request;
	}
	
	//---------------------------------------------------------------------------

	public Element retrieveValues(String parameterName) throws CatalogException {
		return null;
	}

	//---------------------------------------------------------------------------
	
	public static List<Element> handlePropertyName(String[] propertyNames,
			ServiceContext context, boolean freq, int maxRecords) throws Exception {
		 
		List<Element> domainValuesList = null;

		Log.debug(Geonet.CSW,"Handling property names '"+Arrays.toString(propertyNames)+"' with max records of "+maxRecords);
		
		for (int i=0; i < propertyNames.length; i++) {
			
			if (i==0) domainValuesList = new ArrayList<Element>();
			
			// Initialize list of values element.
			Element listOfValues = null;
			
			// Generate DomainValues element
			Element domainValues = new Element("DomainValues", Csw.NAMESPACE_CSW);
			
			// FIXME what should be the type ???
			domainValues.setAttribute("type", "csw:Record");
			
			String property = propertyNames[i].trim();
			
			// Set propertyName in any case.
			Element pn = new Element("PropertyName", Csw.NAMESPACE_CSW);
			domainValues.addContent(pn.setText(property));
			
			GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
			SearchManager sm = gc.getSearchmanager();
			
			IndexSearcher searcher = sm.getNewIndexSearcher().two();

			try {
				Query query = CatalogSearcher.getGroupsQuery(context);
				Sort   sort = LuceneSearcher.makeSort(Collections.singletonList(Pair.read(Geonet.SearchResult.SortBy.RELEVANCE, true)));
				CachingWrapperFilter filter = null;

				Pair<TopDocs,Element> searchResults = LuceneSearcher.doSearchAndMakeSummary( maxRecords, 0, maxRecords, Integer.MAX_VALUE, context.getLanguage(), "results", new Element("summary"), searcher, query, filter, sort, false);
				TopDocs hits = searchResults.one();
		
				
				try {
					// Get mapped lucene field in CSW configuration
					String indexField = CatalogConfiguration.getFieldMapping().get(
							property.toLowerCase());
					if (indexField != null)
						property = indexField;
	
					// check if property name asked for is actually one of those we index
					Collection<String> indexedFieldNames = ReaderUtil.getIndexedFields(searcher.getIndexReader());
					if (!indexedFieldNames.contains(property)) continue;
					
					boolean isRange = false;
					if (CatalogConfiguration.getGetRecordsRangeFields().contains(
							property))
						isRange = true;
					
					if (isRange)
						listOfValues = new Element("RangeOfValues", Csw.NAMESPACE_CSW);
					else	
						listOfValues = new Element("ListOfValues", Csw.NAMESPACE_CSW);

					//List<String> fields = new ArrayList<String>();
					//fields.add(property);
					//fields.add("_isTemplate");
					String fields[] = new String[] { property, "_isTemplate" };
					MapFieldSelector selector = new MapFieldSelector(fields);
	
					// parse each document in the index
					String[] fieldValues;
					SortedSet<String> sortedValues = new TreeSet<String>();
					HashMap<String, Integer> duplicateValues = new HashMap<String, Integer>();
					for (int j = 0; j < hits.scoreDocs.length; j++) {
						Document doc = searcher.getIndexReader().document(hits.scoreDocs[j].doc, selector);
						
						// Skip templates and subTemplates
						String[] isTemplate = doc.getValues("_isTemplate");
						if (isTemplate[0] != null && !isTemplate[0].equals("n"))
							continue;
						
						// Get doc values for specified property
						fieldValues = doc.getValues(property);
						if (fieldValues == null)
							continue;
						
						addtoSortedSet(sortedValues, fieldValues, duplicateValues);
					}
					
					SummaryComparator valuesComparator = new SummaryComparator(SortOption.FREQUENCY, Type.STRING, context.getLanguage(), null);
					TreeSet<Map.Entry<String, Integer>> sortedValuesFrequency = new TreeSet<Map.Entry<String, Integer>>(valuesComparator);
					sortedValuesFrequency.addAll(duplicateValues.entrySet());
					
					if (freq)
						return createValuesByFrequency(sortedValuesFrequency);
					else
						listOfValues.addContent(createValuesElement(sortedValues, isRange));
					
				} finally {
					// any children means that the catalog was unable to determine
					// anything about the specified parameter
					if (listOfValues!= null && listOfValues.getChildren().size() != 0)
						domainValues.addContent(listOfValues);
	
					// Add current DomainValues to the list
					domainValuesList.add(domainValues);
				}
			} finally {
				sm.releaseIndexSearcher(searcher);
			}
		}
		return domainValuesList;
		
	}
	
	//---------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//---------------------------------------------------------------------------
	
	private List<Element> handleParameterName(String[] parameterNames) throws CatalogException {
		Element values;
		List<Element> domainValuesList = null; 
		
		for (int i=0; i < parameterNames.length; i++) {
			
			if (i==0) domainValuesList = new ArrayList<Element>();
			
			// Generate DomainValues element
			Element domainValues = new Element("DomainValues", Csw.NAMESPACE_CSW);
			
			// FIXME what should be the type ???
			domainValues.setAttribute("type", "csw:Record");
			
			String paramName = parameterNames[i];
			
			// Set parameterName in any case.
			Element pn = new Element("ParameterName", Csw.NAMESPACE_CSW);
			domainValues.addContent(pn.setText(paramName));
			
			String operationName = paramName.substring(0, paramName.indexOf('.'));
			String parameterName = paramName.substring(paramName.indexOf('.')+1);
			
			CatalogService cs = checkOperation(operationName);
			values = cs.retrieveValues(parameterName);
			
			// values null mean that the catalog was unable to determine
			// anything about the specified parameter
			if (values != null)
				domainValues.addContent(values);
			
			// Add current DomainValues to the list
			domainValuesList.add(domainValues);
			
		}
		return domainValuesList;
	}

	//---------------------------------------------------------------------------
	
	private CatalogService checkOperation(String operationName)
			throws CatalogException {

		CatalogService cs = CatalogDispatcher.hmServices.get(operationName);

		if (cs == null)
			throw new OperationNotSupportedEx(operationName);

		return cs;
	}
	
	//---------------------------------------------------------------------------

	private String[] getParameters(Element request, String parameter) {
		if (request == null)
		    return null;
		
		Element paramElt = request.getChild(parameter,Csw.NAMESPACE_CSW);
		
		if (paramElt == null)
			return null;
		
		String parameterName = paramElt.getText();
		
		return parameterName.split(",");
	}

	//---------------------------------------------------------------------------
	
	/**
	 * @param sortedValues
	 * @param fieldValues
	 * @param duplicateValues 
	 */
	private static void addtoSortedSet(SortedSet<String> sortedValues,
			String[] fieldValues, HashMap<String, Integer> duplicateValues) {
		for (String value : fieldValues) {
			sortedValues.add(value);
			if (duplicateValues.containsKey(value)) {
				int nb = duplicateValues.get(value);
				duplicateValues.remove(value);
				duplicateValues.put(value, nb+1);
			} else 
				duplicateValues.put(value, 1);
		}
	}
	
	//---------------------------------------------------------------------------

	/**
	 * Create value element for each item of the string array
	 * @param sortedValues
	 * @param isRange
     * @return
	 */
	private static List<Element> createValuesElement(SortedSet<String> sortedValues, boolean isRange) {
		List<Element> valuesList = new ArrayList<Element>();
		if (!isRange) {
            for (String value : sortedValues) {
                valuesList.add(new Element("Value", Csw.NAMESPACE_CSW).setText(value));
            }
		} else {
			valuesList.add(new Element("MinValue",Csw.NAMESPACE_CSW).setText(sortedValues.first()));
			valuesList.add(new Element("MaxValue",Csw.NAMESPACE_CSW).setText(sortedValues.last()));
		}
		return valuesList;
	}
	
	//---------------------------------------------------------------------------

	/**
	 * @param sortedValuesFrequency
	 * @return
	 */
	private static List<Element> createValuesByFrequency(TreeSet<Entry<String, Integer>> sortedValuesFrequency) {
		
		List<Element> values = new ArrayList<Element>();
		Element value;

        for (Object aSortedValuesFrequency : sortedValuesFrequency) {
            Entry<String, Integer> entry = (Entry<String, Integer>) aSortedValuesFrequency;

            value = new Element("Value", Csw.NAMESPACE_CSW);
            value.setAttribute("count", entry.getValue().toString());
            value.setText(entry.getKey());

            values.add(value);
        }
		return values;
	}
	
}

//=============================================================================

