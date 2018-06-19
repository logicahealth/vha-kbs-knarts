This directory contains common static content related to the generation of static reports. 
Notables:

* **conceptual-structure/** A VHA "Conceptual Structure Document": a rendering of an artifact to human-friendly form for non-technical subject matter experts to get a sense of how the initial clinical intent _actually_ is/isn't represented. KNART 1.3 XML - > DocBook 5 XML.
* **schema/** For validations, templating etc.
	* **1.3-revised/** A copy of the HL7 CDS Knowledge Artifacts v1.3 schema with several minor changes to account for errara in the published specification.
	* **composite-draft/** Based on the former, this "r2" schema is necessary to work on composite types included in this repository. At the time of this writing, these are only draft copies from the HL7 KNART working group.

## Licensing

Contents with a copyright from Cognitive Medical Systems has been made available by the vendor under the Apache 2.0 license. You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
and limitations under the License.

